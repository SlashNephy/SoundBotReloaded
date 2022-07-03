import { createReadStream } from 'fs'
import { readdir } from 'fs/promises'
import { join } from 'path'

import {
  AudioPlayerStatus,
  createAudioPlayer,
  createAudioResource,
  demuxProbe,
  entersState,
  generateDependencyReport,
  getVoiceConnection,
  getVoiceConnections,
  joinVoiceChannel,
  NoSubscriberBehavior,
  VoiceConnectionStatus,
} from '@discordjs/voice'
import '@slashnephy/typescript-extension'
import { existsAsync } from '@slashnephy/typescript-extension/dist/node/fs/exists'
import { GatewayIntentBits } from 'discord-api-types/v10'
import { Client } from 'discord.js'

import { env } from './lib/env'

import type { AudioResource, VoiceConnection } from '@discordjs/voice'
import type { VoiceBasedChannel } from 'discord.js'

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.GuildVoiceStates],
})

client.on('ready', () => {
  console.debug(generateDependencyReport())
  console.info(`Logged in as ${client.user?.tag}`)
})

process.on('exit', () => {
  for (const [_, connection] of getVoiceConnections()) {
    connection.destroy()
  }

  client.destroy()
})

client.on('messageCreate', async (message) => {
  if (!message.guildId) {
    return
  }

  if (!/^\.\w+$/.test(message.content)) {
    return
  }

  const channel = message.member?.voice.channel
  if (!channel) {
    // 投稿者が VC に入っていない場合は無視
    return
  }

  const sound = message.content.slice(1)

  let resource: AudioResource | null
  switch (sound) {
    case 'r':
    case 'random':
      resource = await chooseRandomSound(message.guildId)
      break
    default:
      resource = await findSound(sound, message.guildId)
  }

  if (!resource) {
    // 音声ファイルが見つからない場合は無視
    return
  }

  await playAudio(resource, channel)
})

const SOUND_EXTENSIONS = ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac']

const loadAudioResource = async (path: string, name: string): Promise<AudioResource> => {
  const readableStream = createReadStream(path)
  const { stream, type } = await demuxProbe(readableStream)

  const resource = createAudioResource(stream, {
    inputType: type,
    inlineVolume: true,
    metadata: {
      title: name,
    },
  })
  resource.volume?.setVolume(parseFloat(env.INITIAL_VOLUME))

  console.info(`Found sound: ${name} (${path})`)

  return resource
}

const findSound = async (name: string, guildId: string): Promise<AudioResource | null> => {
  const paths = SOUND_EXTENSIONS.map((ext) => join(__dirname, env.SOUNDS_DIRECTORY, guildId, `${name}.${ext}`))

  for (const path of paths) {
    if (!(await existsAsync(path))) {
      continue
    }

    return await loadAudioResource(path, name)
  }

  return null
}

const chooseRandomSound = async (guildId: string): Promise<AudioResource | null> => {
  const directory = join(__dirname, env.SOUNDS_DIRECTORY, guildId)
  if (!(await existsAsync(directory))) {
    return null
  }

  const paths = await readdir(directory)
  const path = paths.filter((path) => SOUND_EXTENSIONS.some((ext) => path.endsWith(`.${ext}`))).random()
  return await loadAudioResource(join(directory, path), path.split('.').slice(0, -1).join('.'))
}

const getOrCreateVoiceConnection = async (channel: VoiceBasedChannel): Promise<VoiceConnection> => {
  const existing = getVoiceConnection(channel.guildId)
  if (existing && existing.state.status === VoiceConnectionStatus.Ready) {
    console.debug(
      `Using existing VoiceConnection for [channel = ${channel.name} (${channel.id}), guild = ${channel.guild.name} (${channel.guildId})]`
    )
    return existing
  }

  return new Promise<VoiceConnection>((resolve, reject) => {
    const created = joinVoiceChannel({
      guildId: channel.guildId,
      channelId: channel.id,
      adapterCreator: channel.guild.voiceAdapterCreator,
    })

    created.on(VoiceConnectionStatus.Ready, () => {
      console.info(
        `Created new VoiceConnection for [channel = ${channel.name} (${channel.id}), guild = ${channel.guild.name} (${channel.guildId})]`
      )

      resolve(created)
    })

    created.on('error', (error) => {
      reject(error)
    })
  })
}

const playAudio = async (resource: AudioResource, channel: VoiceBasedChannel) => {
  // ステージチャンネルではスピーカーリクエストする
  if (channel.type === 'GUILD_STAGE_VOICE' && channel.guild?.me) {
    await channel.guild.me.voice.setRequestToSpeak(true)
    console.info(
      `Requested to speak for [channel = ${channel.name} (${channel.id}), guild = ${channel.guild.name} (${channel.guildId})]`
    )
  }

  const voice = await getOrCreateVoiceConnection(channel)
  voice.on(VoiceConnectionStatus.Disconnected, async () => {
    // https://discordjs.guide/voice/voice-connections.html#handling-disconnects
    try {
      await Promise.race([
        entersState(voice, VoiceConnectionStatus.Signalling, 5_000),
        entersState(voice, VoiceConnectionStatus.Connecting, 5_000),
      ])
    } catch (error) {
      console.error(error)
      voice.destroy()
    }
  })

  const player = createAudioPlayer({
    behaviors: {
      noSubscriber: NoSubscriberBehavior.Stop,
    },
  })

  const subscription = voice.subscribe(player)
  if (subscription) {
    setTimeout(() => subscription.unsubscribe(), 5_000)
  }

  player.play(resource)
  await entersState(player, AudioPlayerStatus.Playing, 5_000)
}

client.login(env.DISCORD_TOKEN).catch(console.error)
