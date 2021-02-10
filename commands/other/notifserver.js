const MessageEmbed = require('discord.js').MessageEmbed;

module.exports = {
    name: "notifserver",
    description: "Obtenir le lien de téléchargement du systeme de notification serveur de DevinciApp",
    run: async (env, client, message, args) => {
        let embed = new MessageEmbed()
            .setColor('#87CEFA')
            .setTitle(`Systéme de notification coté serveur de DevinciApp`)
            .setThumbnail(message.guild.iconURL())
            .setDescription("Vous pouvez suivre un tutoriel ici : \n*" + env.URL_TUTO_SERVER + "*\n\nNotre discord :\n*" + env.URL_DISCORD + "*")
            .setFooter(env.FOOTER)
            .setURL(env.URL_SERVER)
        message.author.send(embed)
        message.delete()
    }
}
