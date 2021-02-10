const MessageEmbed = require('discord.js').MessageEmbed;
const fs = require("fs");

module.exports = {
    name: "close",
    description: "Fermer un ticket",
    run: async (env, client, message, args) => {
        var ticketList = fs.readFileSync(env.STORAGE_PATH + "ticket_list.json");
        ticketList = JSON.parse(ticketList);
        if (ticketList[message.channel.id]) {
            if (!args) {
                args = "La raison n'as pas été saisie"
            }
            message.channel.delete("Fermeture du ticket")
            delete ticketList[message.channel.id];
            fs.writeFileSync(env.STORAGE_PATH + "ticket_list.json", JSON.stringify(ticketList));
        }
        message.delete()
    }
}
