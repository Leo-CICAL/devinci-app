const MessageEmbed = require('discord.js').MessageEmbed; 
const { formatDate } = require('../functions')
const fs = require('fs')
const GitHub = require('github-api');

module.exports = {
    run: (env, client, message,args) => {
        
        if (message.author.bot) return;
        if (!message.guild) return;
        if (message.content.startsWith(env.PREFIX)) return;

        var ticketList = fs.readFileSync(env.STORAGE_PATH + "ticket_list.json");
        ticketList = JSON.parse(ticketList);
        if (ticketList[message.channel.id]){
            if (ticketList[message.channel.id]['authorId'] == message.author.id){
                if (ticketList[message.channel.id]['status'] == 0){
                    message.delete()
                    ticketList[message.channel.id]['title'] = message.content;
                    ticketList[message.channel.id]['status'] = 1
                    let embed1 = new MessageEmbed()
                        .setColor('#87CEFA')
                        .setTitle(ticketList[message.channel.id]['title'])
                        .setDescription(`Merci de bien vouloir saisir une description pour votre ticket`)
                        .setThumbnail(message.guild.iconURL())
                        .setFooter(env.FOOTER)
                    message.channel.send(embed1).then(msg => {
                        message.channel.messages.fetch(ticketList[message.channel.id]['lastBotMessage']).then(deletemsg=>{
                            deletemsg.delete()
                        })
                        ticketList[message.channel.id]['lastBotMessage'] = msg.id;
                        fs.writeFileSync(env.STORAGE_PATH + "ticket_list.json", JSON.stringify(ticketList))
                    })

                } else if (ticketList[message.channel.id]['status'] == 1) {
                    message.delete()
                    ticketList[message.channel.id]['description'] = message.content;
                    ticketList[message.channel.id]['status'] = 2

                    let embed1 = new MessageEmbed()
                        .setColor('#87CEFA')
                        .setTitle(ticketList[message.channel.id]['title'])
                        .setDescription(ticketList[message.channel.id]['description'] +"\n\nMerci de nous avois contacté, Nous vous répondrons dans les plus bref delaie")
                        .setThumbnail(message.guild.iconURL())
                        .setFooter(env.FOOTER)
                    message.channel.send(embed1).then(msg => {
                        message.channel.messages.fetch(ticketList[message.channel.id]['lastBotMessage']).then(deletemsg => {
                            deletemsg.delete()
                        })
                        ticketList[message.channel.id]['lastBotMessage'] = msg.id;
                        fs.writeFileSync(env.STORAGE_PATH + "ticket_list.json", JSON.stringify(ticketList))

                        // var gh = new GitHub({
                        //     username: env.GITHUB_USERNAME,
                        //     password: env.GITHUB_PASSWORD,
                        //     token: env.GITHUB_TOKEN
                        // }); 
                        // var me = gh.getIssues("clashoux","test");
                        // me.createIssue({
                        //     "title": ticketList[message.channel.id]['title'],
                        //     "body": ticketList[message.channel.id]['description'],
                        // },(err, result, request) =>{
                        //         if (err) console.log(err);
                        // })


                        
                    })
                }
            }                    
        }
        return;
    }
}