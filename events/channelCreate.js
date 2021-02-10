const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')

module.exports = {
  run: (env, client, channel) => {
    let ctype;
    if (channel.type === "text") {
      ctype = "Texte";
    } else if (channel.type === "voice") {
      ctype = "Vocal";
    } else if (channel.type === "category") {
      ctype = "Catégorie"
    } else if (channel.type === "news") {
      ctype = "Annonce"
    }

    const embed = new MessageEmbed()
      .setTitle(env.LOGS_NAME)
      .setDescription(`Un salon vient d'être créer !`)
      .setColor('#36EE09')
      .setFooter(env.FOOTER)
      .addField(`Nom du channel :`, channel.name)
      .addField(`Id du channel :`, channel.id)
      .addField(`Créé le :`, formatDate(channel.createdAt))
      .addField(`Type du channel :`, ctype)
    channel.guild.channels.cache.get(env.CHANNEL_LOGS).send(embed)

    return;
  }
}