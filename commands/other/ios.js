const MessageEmbed = require('discord.js').MessageEmbed;

module.exports = {
    name: "ios",
    description: "Obtenir le lien de téléchargement de l'application sur IOS",
    run: async (env, client, message, args) => {
        let embed = new MessageEmbed()
            .setColor('#87CEFA')
            .setTitle(`Application Devinci sur IOS`)
            .setThumbnail(message.guild.iconURL())
            .setDescription("Vous pouvez suivre un tutoriel ici : \n*" + env.URL_TUTO_IOS + "*\n\nPour obtenir l'application sur android taper **" + env.PREFIX + "android** sur le discord : \n*" + env.URL_DISCORD+"*")
            .setFooter(env.FOOTER)
            .setURL(env.URL_IOS)
        message.author.send(embed)
        message.delete()
    }
}
