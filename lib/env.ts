import dotenv from 'dotenv'

export type EnvConfig = {
  DISCORD_TOKEN: string
  SOUNDS_DIRECTORY: string
  INITIAL_VOLUME: string
}

const checkEnv = (key: keyof EnvConfig) => {
  const env = process.env as EnvConfig
  if (!env[key]) {
    throw new Error(`${key} is not defined`)
  }
}

const setDefaultEnv = (key: keyof EnvConfig, value: string): void => {
  const env = process.env as EnvConfig
  if (!env[key]) {
    env[key] = value
  }
}

const initializeEnv = (): EnvConfig => {
  dotenv.config()

  checkEnv('DISCORD_TOKEN')
  setDefaultEnv('SOUNDS_DIRECTORY', 'sounds')
  setDefaultEnv('INITIAL_VOLUME', '1.0')

  return process.env as EnvConfig
}

export const env = initializeEnv()
