const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')

module.exports = {
    run: (env, client, oldRole, newRole) => {
        const embed = new MessageEmbed()
            .setTitle(env.LOGS_NAME)
            .setDescription(`Un role vient d'être édité !`)
            .setColor('#ff3300')
            .setFooter(env.FOOTER)
            .addField(`Ancien nom du role :`, oldRole.name)
            .addField(`Ancienne couleur du role :`, oldRole.hexColor)
            .addField(`Nouveau nom du role :`, newRole.name)
            .addField(`Nouvelle couleur du role :`, newRole.hexColor)
            .addField(`Id du role :`, oldRole.id)
            .addField(`Créé le :`, formatDate(oldRole.createdAt))
        oldRole.guild.channels.cache.get(env.CHANNEL_LOGS).send(embed)
        return;
    }
}