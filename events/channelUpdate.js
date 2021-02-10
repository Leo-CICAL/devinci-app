const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')

module.exports = {
  run: (env, client, oldChannel, newChannel) => {
    if (newChannel.hexColor == undefined){
      newChannel.hexColor = "Non défini"
    }
    if (oldChannel.hexColor == undefined){
      oldChannel.hexColor = "Non défini"
    }
    const embed = new MessageEmbed()
      .setTitle(env.LOGS_NAME)
      .setDescription(`Un channel vient d'être édité !`)
      .setColor('#ffc966')
      .setFooter(env.FOOTER)
      .addField(`Ancien nom du channel :`, oldChannel.name)
      .addField(`Ancienne couleur du channel :`, oldChannel.hexColor)
      .addField(`Nouveau nom du channel :`, newChannel.name)
      .addField(`Nouvelle couleur du channel :`, newChannel.hexColor)
      .addField(`Id du role :`, oldChannel.id)
      .addField(`Créé le :`, formatDate(oldChannel.createdAt))
    oldChannel.guild.channels.cache.get(env.CHANNEL_LOGS).send(embed)
    return;
  }
}