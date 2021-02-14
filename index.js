const { Client, Collection, MessageEmbed } = require("discord.js");
const { config } = require("dotenv");
const fs = require("fs");

const client = new Client({
    disableEveryone: true
});

client.commands = new Collection();
client.aliases = new Collection();

client.categories = fs.readdirSync("./commands/");

config({
    path: __dirname + "/.env"
});

["command"].forEach(handler => {
    require(`./handlers/${handler}`)(client);
});

client.on("ready", () => {
    console.log('DevinciBot est actuellement lancé')
    console.log(`
    #####################################
    #                                   #
    #          DevinciApp - Bot         #
    #                                   #
    #####################################
    `);

    client.user.setPresence({ 
            activity: { 
                name: process.env.ACTIVITY_STATUS, 
                type: 'CUSTOM_STATUS',
            }, 
            status: 'online' 
        }); 
});

fs.readdir("./events/", (err, files) => {
    if (err) return console.error(err);
    files.forEach(file => {
        const eventFile = require(`./events/${file}`);
        let eventName = file.split(".")[0];
        client.on(eventName, (...args) =>{
            eventFile.run(process.env, client, ...args)
        });
    });
});


client.on("message", async message => {
    const prefix = process.env.PREFIX;

    if (message.author.bot) return;
    if (!message.guild) return;
    if (!message.content.startsWith(prefix)) return;
    if (!message.member) message.member = await message.guild.fetchMember(message);

    const args = message.content.slice(prefix.length).trim().split(/ +/g);
    const cmd = args.shift().toLowerCase();
    
    if (cmd.length === 0) return;
    
    let command = client.commands.get(cmd);
    if (!command) command = client.commands.get(client.aliases.get(cmd));

    if (command) 
        command.run(process.env, client, message, args);
});







client.login(process.env.TOKEN);