const { MessageEmbed } = require('discord.js');

const defEmojiList = [
    '\u0031\u20E3',
    '\u0032\u20E3',
    '\u0033\u20E3',
    '\u0034\u20E3',
    '\u0035\u20E3',
    '\u0036\u20E3',
    '\u0037\u20E3',
    '\u0038\u20E3',
    '\u0039\u20E3',
    '\uD83D\uDD1F'
];

const pollEmbed = async (channel, title, options, timeout = 30, emojiList = defEmojiList.slice(), forceEndPollEmoji = '\u2705', gamerzEmoji, member) => {
    let text = `**${member} - DEMOKRACY**\n\n\n`;
    let gamerz = false;
    const emojiInfo = {};
    for (const option of options) {
        const emoji = emojiList.splice(0, 1);
        emojiInfo[emoji] = { option: option, votes: 0 };
        text += `${emoji} : \`${option}\`\n\n`;
    }
    const usedEmojis = Object.keys(emojiInfo);
    usedEmojis.push(forceEndPollEmoji);

    const poll = await channel.send(embedBuilder(title).setDescription(text));
    for (const emoji of usedEmojis) await poll.react(emoji);

    const reactionCollector = poll.createReactionCollector(
        (reaction, user) => usedEmojis.includes(reaction.emoji.name) && !user.bot,
        timeout === 0 ? {} : { time: timeout * 1000 }
    );
    const voterInfo = new Map();
    reactionCollector.on('collect', async (reaction, user) => {
        if (usedEmojis.includes(reaction.emoji.name)) {
            console.log(`got reaction ! ${reaction.emoji.name} de la part de ${user.id}`);
            if (reaction.emoji.name === gamerzEmoji) {
                gamerz = true;
                return reactionCollector.stop();
            }
            if (reaction.emoji.name === forceEndPollEmoji && ("402094515894353921" === user.id || "529281109482012672" === user.id)) return reactionCollector.stop();
            if (!voterInfo.has(user.id)) voterInfo.set(user.id, { emoji: reaction.emoji.name });
            const votedEmoji = voterInfo.get(user.id).emoji;
            if (votedEmoji !== reaction.emoji.name) {
                const userReactions = poll.reactions.cache.filter(reaction => reaction.users.cache.has(user.id));
                try {
                    for (const reaction of userReactions.values()) {
                        await reaction.users.remove(user.id);
                    }
                } catch (error) {
                    console.error(error);
                }
                emojiInfo[votedEmoji].votes -= 1;
                voterInfo.set(user.id, { emoji: reaction.emoji.name });
            }
            emojiInfo[reaction.emoji.name].votes += 1;
        }
    });

    reactionCollector.on('dispose', (reaction, user) => {
        if (usedEmojis.includes(reaction.emoji.name)) {
            voterInfo.delete(user.id);
            emojiInfo[reaction.emoji.name].votes -= 1;
        }
    });

    reactionCollector.on('end', () => {
        if (gamerz) {
            text = `*GAMERZ*\n\n${member} est maintenant un Gamerz, bon jeu !`;
            const douane = member.guild.roles.cache.find(role => role.id === '702413171490816010');
            const inconnu = member.guild.roles.cache.find(role => role.id === '760402995833208833');
            const gamerz = member.guild.roles.cache.find(role => role.id === '805728478334025738');
            console.log(douane);
            console.log(inconnu);
            console.log(gamerz);
            member.roles.add(inconnu);
            member.roles.add(gamerz);
            member.roles.remove(douane);
        } else {
            text = '*Ding! Ding! Ding! Voici les résultats très très démocratique :*\n\n';
            var oui = 0;
            var non = 0;
            for (const emoji in emojiInfo) {

                text += `\`${emojiInfo[emoji].option}\` - \`${emojiInfo[emoji].votes}\`\n\n`;
                if (emojiInfo[emoji].option == "oui") oui = emojiInfo[emoji].votes;
                else non = emojiInfo[emoji].votes;
            }
            if (oui >= non) {
                text += `Le peuple a voté en faveur de ${member}, bienvenue parmis nous !`;
                const douane = member.guild.roles.cache.find(role => role.id === '702413171490816010');
                const inconnu = member.guild.roles.cache.find(role => role.id === '760402995833208833');
                console.log(douane);
                console.log(inconnu);
                member.roles.add(inconnu);
                member.roles.remove(douane);
            } else {
                text += `Le peuple a voté en défaveur de ${member}, la sentance est irrévocable, DEGAGE !`;
                member.kick();
            }
        }

        poll.delete();
        channel.send(embedBuilder(title).setDescription(text));
    });
};

const embedBuilder = (title) => {
    return new MessageEmbed()
        .setTitle(`${title}`)
};

module.exports = pollEmbed;