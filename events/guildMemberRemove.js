const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')

module.exports = {
    run: (env, client, member) => {
        const embed1 = new MessageEmbed()
            .setTitle(env.LOGS_NAME)
            .setDescription(`Un utilisateur a quitté le discord`)
            .setColor('#ff6666')
            .setFooter(env.FOOTER)
            .setThumbnail(member.user.displayAvatarURL())
            .addField(`Nom de l'utilisateur :`, member.user)
            .addField(`Tag de l'utilisateur :`, member.user.tag)
            .addField(`ID utilisateur :`, member.user.id)
            .addField(`Compte créer le :`, formatDate(member.user.createdAt))
            .addField(`Nombre d'utilisateur sur le discord :`, member.guild.memberCount)
        member.guild.channels.cache.get(env.CHANNEL_LOGS).send(embed1)
        return;
    }
}