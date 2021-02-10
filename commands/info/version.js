const MessageEmbed = require('discord.js').MessageEmbed;
const { formatDate } = require("../../functions.js");

module.exports = {
    name: "version",
    description: "Version du bot",
    run: async (env, client, message, args) => {
        let embed = new MessageEmbed()
            .setColor('2f3136')
            .setTitle(`Le bot est en version : 1.0.0`)
        message.channel.send(embed);

    }
}
