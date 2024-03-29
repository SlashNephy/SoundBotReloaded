import { generateDependencyReport, getVoiceConnections } from '@discordjs/voice'
import '@slashnephy/typescript-extension'
import { GatewayIntentBits } from 'discord-api-types/v10'
import { Client, Message } from 'discord.js'

import { handleSoundCommand } from './lib/bot'
import { env } from './lib/env'

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.GuildVoiceStates,
    GatewayIntentBits.MessageContent,
  ],
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

const handleMessage = async (message: Message) => {
  if (!message.guildId) {
    return
  }

  if (!message.content.startsWith('.')) {
    return
  }

  const sound = message.content.slice(1)
  const channel = message.member?.voice.channel
  if (!channel) {
    return
  }

  await handleSoundCommand(sound, channel, async (name) => {
    await message.channel?.send(`=> ${name}`)
  })
}

client.on('messageCreate', handleMessage)
client.on('messageUpdate', async (_, message) => {
  if (message instanceof Message) {
    await handleMessage(message)
  }
})

client.login(env.DISCORD_TOKEN).catch(console.error)
