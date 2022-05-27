//urediti

window.addEventListener('message', function(event)
{ 
    var trigger = event.data;
    switch(trigger.action) {
        case 'open':
            document.getElementById('tablet').style.display = 'flex'
            Rev.Announces = trigger.announces
            Rev.Player = trigger.info
            Rev.Config = trigger.config
            Rev.RankList = trigger.rankList
            Rev.func.show.home({announces : Rev.Announces})
            Rev.func.initHome(Rev.Player)
            return;
        case 'reveal-scoreboard':
            document.getElementById('scoreboard').style.display = 'block'
            return
        case 'unreveal-scoreboard':
            document.getElementById('scoreboard').style.display = 'none'
            return
        case 'onchange-scoreboard':
            document.getElementById('scoreboard-defend').innerHTML = trigger.minutes.defend
            document.getElementById('scoreboard-attack').innerHTML = trigger.minutes.attack
            document.getElementById('scoreboard-session').innerHTML = trigger.session
            return
        default:
            return;
    }
});


document.onkeyup = function (data) {
    if (data.which == 27) {
        document.getElementById('tablet').style.display = 'none'
        Rev.func.closeTablet()
    }
};