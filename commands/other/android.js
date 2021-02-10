const MessageEmbed = require('discord.js').MessageEmbed;

module.exports = {
    name: "android",
    description: "Obtenir le lien de téléchargement de l'application sur android",
    run: async (env, client, message, args) => {
        let embed = new MessageEmbed()
            .setColor('#87CEFA')
            .setTitle(`Application Devinci sur Android`)
            .setThumbnail(message.guild.iconURL())
            .setDescription("Vous pouvez suivre un tutoriel ici : \n*" + env.URL_TUTO_ANDROID + "*\n\nPour obtenir l'application sur ios taper **" + env.PREFIX + "ios** sur le discord : \n*" + env.URL_DISCORD + "*")
            .setFooter(env.FOOTER)
            .setURL(env.URL_ANDROID)
        message.author.send(embed)
        message.delete()
    }
}
