import { chooseRandomSound, findSound } from './sound'
import { playAudio } from './voice'

import type { AudioMetadata } from './voice'
import type { AudioResource } from '@discordjs/voice'
import type { VoiceBasedChannel } from 'discord.js'

export const handleSoundCommand = async (
  sound: string,
  channel: VoiceBasedChannel,
  onSuccess: (name: string) => Promise<void>
): Promise<void> => {
  let resource: AudioResource<AudioMetadata> | null
  switch (sound) {
    case 'r':
    case 'random':
      resource = await chooseRandomSound(channel.guildId)
      break
    default:
      resource = await findSound(sound, channel.guildId)
  }

  // 音声ファイルが見つからない場合は無視
  if (!resource) {
    return
  }

  await playAudio(resource, channel)

  if (resource?.metadata?.title) {
    await onSuccess(resource.metadata.title)
  }
}
