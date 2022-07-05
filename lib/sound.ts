import { readdir } from 'fs/promises'
import { join } from 'path'

import { existsAsync } from '@slashnephy/typescript-extension/dist/node/fs/exists'

import { env } from './env'
import { loadAudioResource } from './voice'

import type { AudioMetadata } from './voice'
import type { AudioResource } from '@discordjs/voice'

const SOUND_EXTENSIONS = ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac']

export const findSound = async (name: string, guildId: string): Promise<AudioResource<AudioMetadata> | null> => {
  if (name.endsWith('?')) {
    return await findSoundFuzzy(name.slice(0, -1), guildId)
  }

  const paths = SOUND_EXTENSIONS.map((ext) => join(process.cwd(), env.SOUNDS_DIRECTORY, guildId, `${name}.${ext}`))

  for (const path of paths) {
    if (!(await existsAsync(path))) {
      continue
    }

    return await loadAudioResource(path, name)
  }

  return null
}

export const findSoundFuzzy = async (name: string, guildId: string): Promise<AudioResource<AudioMetadata> | null> => {
  const { levenshteinEditDistance } = await import('levenshtein-edit-distance')

  const directory = join(process.cwd(), env.SOUNDS_DIRECTORY, guildId)
  if (!(await existsAsync(directory))) {
    return null
  }

  const filenames = await readdir(directory)
  const filename = filenames.minBy((filename) =>
    levenshteinEditDistance(name, filename.split('.').slice(0, -1).join('.'))
  )

  const path = join(process.cwd(), env.SOUNDS_DIRECTORY, guildId, filename)
  if (!(await existsAsync(path))) {
    return null
  }

  return await loadAudioResource(path, filename.split('.').slice(0, -1).join('.'))
}

export const chooseRandomSound = async (guildId: string): Promise<AudioResource<AudioMetadata> | null> => {
  const directory = join(process.cwd(), env.SOUNDS_DIRECTORY, guildId)
  if (!(await existsAsync(directory))) {
    return null
  }

  const filenames = await readdir(directory)
  const path = filenames.filter((path) => SOUND_EXTENSIONS.some((ext) => path.endsWith(`.${ext}`))).random()

  return await loadAudioResource(join(directory, path), path.split('.').slice(0, -1).join('.'))
}
