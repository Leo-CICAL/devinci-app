const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')
const fs = require('fs')

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

    var ticketList = fs.readFileSync(env.STORAGE_PATH + "ticket_list.json");
    ticketList = JSON.parse(ticketList);
    if (ticketList[channel.id]){
      delete ticketList[channel.id];
      fs.writeFileSync(env.STORAGE_PATH + "ticket_list.json", JSON.stringify(ticketList));
    }


    const embed = new MessageEmbed()
      .setTitle(env.LOGS_NAME)
      .setDescription(`Un salon vient d'être suprimmé !`)
      .setColor('#ff6666')
      .setFooter(env.FOOTER)
      .addField(`Nom du channel :`, channel.name)
      .addField(`Id du channel :`, channel.id)
      .addField(`Créé le :`, formatDate(channel.createdAt))
      .addField(`Type du channel :`, ctype)
    channel.guild.channels.cache.get(env.CHANNEL_LOGS).send(embed)
    return;
  }
}