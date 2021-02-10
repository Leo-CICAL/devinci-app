module.exports = {
    name: "ping",
    description: "Returns latency and API ping",
    run: async (env, client, message, args) => {
        if (message.author.id != message.guild.owner.id) {
            const msg = await message.channel.send(`🏓 Pinging....`);
            msg.edit(`🏓 Pong!
        Latency is ${Math.floor(msg.createdTimestamp - message.createdTimestamp)}ms
        API Latency is ${Math.round(client.ping)}ms`);
        }else{
            message.delete();
        }
    }
}
