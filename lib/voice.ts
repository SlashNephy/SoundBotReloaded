import { createReadStream } from 'fs'

import {
  AudioPlayerStatus,
  createAudioPlayer,
  createAudioResource,
  demuxProbe,
  entersState,
  getVoiceConnection,
  joinVoiceChannel,
  NoSubscriberBehavior,
  VoiceConnectionStatus,
} from '@discordjs/voice'
import { ChannelType } from 'discord.js'

import { env } from './env'

import type { AudioResource, VoiceConnection } from '@discordjs/voice'
import type { VoiceBasedChannel, GuildMember } from 'discord.js'

export type AudioMetadata = {
  title: string
}

export const loadAudioResource = async (path: string, name: string): Promise<AudioResource<AudioMetadata>> => {
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

  console.info(`Load sound: ${name} (${path})`)

  return resource
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

    created.on(VoiceConnectionStatus.Disconnected, async () => {
      // https://discordjs.guide/voice/voice-connections.html#handling-disconnects
      try {
        await Promise.race([
          entersState(created, VoiceConnectionStatus.Signalling, 5_000),
          entersState(created, VoiceConnectionStatus.Connecting, 5_000),
        ])
      } catch (error) {
        console.error(error)
        created.destroy()
      }
    })

    created.on('error', (error) => {
      reject(error)
    })
  })
}

// なぜか Guild から get me() が欠けているので補完
declare module 'discord.js' {
  interface Guild {
    get me(): GuildMember | null
  }
}

export const playAudio = async (resource: AudioResource, channel: VoiceBasedChannel) => {
  // ステージチャンネルではスピーカーリクエストする
  if (channel.type === ChannelType.GuildStageVoice && channel.guild?.me) {
    await channel.guild.me.voice.setRequestToSpeak(true)
    console.info(
      `Requested to speak for [channel = ${channel.name} (${channel.id}), guild = ${channel.guild.name} (${channel.guildId})]`
    )
  }

  const voice = await getOrCreateVoiceConnection(channel)

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
