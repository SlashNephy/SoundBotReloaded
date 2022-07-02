import { createReadStream } from 'fs'
import { join } from 'path'

import {
  createAudioPlayer,
  createAudioResource,
  demuxProbe,
  generateDependencyReport,
  getVoiceConnection,
  joinVoiceChannel,
  NoSubscriberBehavior,
  VoiceConnectionStatus,
} from '@discordjs/voice'
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

client.on('messageCreate', async (message) => {
  if (!message.guildId) {
    return
  }

  if (!/^\.\w+$/.test(message.content)) {
    return
  }

  const sound = message.content.slice(1)

  const channel = message.member?.voice.channel
  if (!channel) {
    // 投稿者が VC に入っていない場合は無視
    return
  }

  const resource = await findSound(sound, message.guildId)
  if (!resource) {
    // 音声ファイルが見つからない場合は無視
    return
  }

  await playAudio(resource, channel)
})

const findSound = async (name: string, guildId: string): Promise<AudioResource | null> => {
  const SOUND_EXTENSIONS = ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac']
  const paths = SOUND_EXTENSIONS.map((ext) => join(__dirname, env.SOUNDS_DIRECTORY, guildId, `${name}.${ext}`))

  for (const path of paths) {
    if (!(await existsAsync(path))) {
      continue
    }

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

  return null
}

const getOrCreateVoiceConnection = async (channel: VoiceBasedChannel): Promise<VoiceConnection> => {
  const existing = getVoiceConnection(channel.guildId)
  if (existing) {
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

  const player = createAudioPlayer({
    debug: true,
    behaviors: {
      noSubscriber: NoSubscriberBehavior.Stop,
    },
  })
  player.play(resource)

  const voice = await getOrCreateVoiceConnection(channel)
  voice.subscribe(player)
}

client.login(env.DISCORD_TOKEN).catch(console.error)
