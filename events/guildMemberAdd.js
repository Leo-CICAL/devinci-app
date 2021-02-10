const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')

module.exports = {
    run: (env, client, member) => {
        const embed = new MessageEmbed()
            .setTitle("Bienvenue sur DevinciApp")
            .setDescription(`Toutes l\'équipe de DevinciApp te souhaite la bienvenue !\n
            Application Devinci sur IOS :
            *${env.URL_IOS}*

            Application Devinci sur Android :
            *${env.URL_ANDROID}*
            
            Pour ouvrir un ticket support :
            Taper la commandes **!open** sur le discord
            `)
            .setColor('#bfff00')
            .setFooter(env.FOOTER)
        member.send(embed)


        const embed1 = new MessageEmbed()
            .setTitle(env.LOGS_NAME)
            .setDescription(`Un utilisateur a rejoint le discord`)
            .setColor('#36EE09')
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