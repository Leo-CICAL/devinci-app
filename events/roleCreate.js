const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require('../functions')

module.exports = {
    run: (env, client, args) => {
        const embed = new MessageEmbed()
            .setTitle(env.LOGS_NAME)
            .setDescription(`Un role vient d'être créer !`)
            .setColor('#36EE09')
            .setFooter(env.FOOTER)
            .addField(`Nom du role :`, args.name)
            .addField(`Tag du role :`, args)
            .addField(`Id du role :`, args.id)
            .addField(`Couleur du role :`, args.hexColor)
            .addField(`Créé le :`, formatDate(args.createdAt))
        args.guild.channels.cache.get(env.CHANNEL_LOGS).send(embed)
        return;
    }
}