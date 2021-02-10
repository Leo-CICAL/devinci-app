const MessageEmbed = require('discord.js').MessageEmbed;
const fs = require("fs");

module.exports = {
    name: "open",
    description: "Ouvrir un ticket",
    run: async (env, client, message, args) => {
        var ticketInfo = fs.readFileSync(env.STORAGE_PATH + "ticket_info.json");
        var ticketList = fs.readFileSync(env.STORAGE_PATH + "ticket_list.json");
        ticketInfo = JSON.parse(ticketInfo); 
        ticketList = JSON.parse(ticketList);
        ticketInfo.ticketCount = ticketInfo.ticketCount+1;

        message.guild.channels.create('ticket-' + ticketInfo.ticketCount, { //Create a channel
            type: 'text', //Make sure the channel is a text channel
            permissionOverwrites: [
                { //Set permission overwrites
                    id: message.author.id,
                    allow: ['VIEW_CHANNEL','SEND_MESSAGES'],
                }, 
                { //Set permission overwrites
                        id: message.guild.id,
                        deny: ['VIEW_CHANNEL', 'SEND_MESSAGES'],
                },
                { //Set permission overwrites
                    id: env.SUPPORT_ID_ROLE,
                    allow: ['VIEW_CHANNEL', 'SEND_MESSAGES'],
                }, 
            ]
        }).then(channel =>{
            let embed1 = new MessageEmbed()
            .setColor('#87CEFA')
            .setTitle(`Votre ticket #` + ticketInfo.ticketCount)
            .setDescription(`Merci de bien vouloir saisir un titre pour votre ticket`)
            .setThumbnail(message.guild.iconURL())
            .setFooter(env.FOOTER)
            channel.send(embed1).then(msg => {
                ticketList[channel.id] = {};
                ticketList[channel.id]['authorId'] = message.author.id;
                ticketList[channel.id]['lastBotMessage'] = msg.id;
                ticketList[channel.id]['status'] = 0;
                fs.writeFileSync(env.STORAGE_PATH + "ticket_list.json", JSON.stringify(ticketList))
            })
        })
        fs.writeFileSync(env.STORAGE_PATH + "ticket_info.json", JSON.stringify(ticketInfo))


        // let embed = new MessageEmbed()
        //     .setColor('#87CEFA')
        //     .setTitle(`Systéme de notification coté serveur de DevinciApp`)
        //     .setThumbnail(message.guild.iconURL())
        //     .setDescription("Vous pouvez suivre un tutoriel ici : \n*" + env.URL_TUTO_SERVER + "*\n\nNotre discord :\n*" + env.URL_DISCORD + "*")
        //     .setFooter(env.FOOTER)
        //     .setURL(env.URL_SERVER)
        // message.author.send(embed)
        message.delete()
    }
}
