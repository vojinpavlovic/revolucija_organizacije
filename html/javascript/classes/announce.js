// This is temporary I didn't quite get javascript dates formats but I will update it

const dateDict = {
    month : {
        0 : 'Januar',
        1 : 'Februar',
        2 : 'Mart',
        3 : 'April',
        4 : 'Maj',
        5 : 'Jun',
        6 : 'Jul',
        7 : 'Avgust',
        8 : 'Septembar',
        9 : 'Oktobar',
        10 : 'Novembar',
        11 : 'Decembar',
    },
    hours : {
        0 : ['01', 'AM'],
        1 : ['02', 'AM'],
        2 : ['03', 'AM'],
        3 : ['04', 'AM'],
        4 : ['05', 'AM'],
        5 : ['06', 'AM'],
        6 : ['07', 'AM'],
        7 : ['08', 'AM'],
        8 : ['09', 'AM'],
        9 : ['10', 'AM'],
        10 : ['11', 'AM'],

        11 : ['12', 'PM'],
        12 : ['01', 'PM'],
        13 : ['02', 'PM'],
        14 : ['03', 'PM'],
        15 : ['04', 'PM'],
        16 : ['05', 'PM'],
        17 : ['06', 'PM'],
        18 : ['07', 'PM'],
        19 : ['08', 'PM'],
        20 : ['09', 'PM'],
        21 : ['10', 'PM'],
        22 : ['11', 'PM'],
        23 : ['12', 'AM']
    }
}

class Announce {
    constructor(owner, title, message, timestamp, uuid) {
        this.owner = owner;
        this.title = title;
        this.message = message;
        this.timestamp = timestamp;
        this.expand = false
        this.uuid = uuid
    }

    createContainer() {
        let box = document.createElement('div')
        box.classList.add('announce-box');

        return box
    }

    expandButton(element) {
        let button = document.createElement('button');
        button.innerHTML = '<i class="fas fa-eye"></i> Prikazi vise'
        button.style.opacity = '0.7'

        button.onclick = function() {
            if (!this.expand) {
                element.style.maxHeight = '200px';
                this.expand = !this.expand
                button.innerHTML = '<i class="fas fa-eye-slash"></i> Prikazi manje'
                return
            }
            this.expand = !this.expand
            element.style.maxHeight = '75px';
            button.innerHTML = '<i class="fas fa-eye"></i> Prikazi vise'
        }

        return button
    }

    editButton() {
        let button = document.createElement('button')
        button.innerHTML = '<i class="fas fa-edit"></i> Uredi'
        button.style.opacity = '0.7'

        let data = {
            title : this.title,
            message : this.message,
            uuid : this.uuid
        }

        button.onclick = function() {
            Rev.func.show.announceInput(data)
        }

        return button
    }

    createContent() {
        let data = {
            title : document.createElement('h1'),
            owner : document.createElement('h2'),
            date : document.createElement('span'),
            message : document.createElement('p'),
            actions : document.createElement('div'),
        }

        data.title.innerHTML = this.title,
        data.owner.innerHTML = this.owner,
        data.date.innerHTML = this.formatDate(this.timestamp)
        data.message.innerHTML = this.message

        data.owner.appendChild(data.date)

        return data
    }
    
    create() {
        let isBtnContainer = false

        let container = this.createContainer()
        let content = this.createContent()

        container.appendChild(content.title)
        container.appendChild(content.owner)
        container.appendChild(content.message)
        container.appendChild(content.actions)

        document.getElementById('new-announce').style.display = 'none'

        Rev.Wrappers.home.announces.appendChild(container)

        if (content.message.offsetHeight > 50) {
            content.message.style.maxHeight = '75px'
            content.actions.appendChild(this.expandButton(content.message))
            isBtnContainer = true
        } 
        
        let job = Rev.Player['job_name'].result
        let grade = Rev.Player['grade_name'].result

        let permissions = {
            edit : true,
            new : true
        }

        if (typeof Rev.Config.Org.list[job].announces.edit[grade] === 'undefined') {
            permissions.edit = false
        }
        
        if (typeof Rev.Config.Org.list[job].announces.new[grade] === 'undefined') {
            permissions.new = false
        }

        if (permissions.edit) {
            content.actions.appendChild(this.editButton())
            isBtnContainer = true
        } 

        if (permissions.new) {
            document.getElementById('new-announce').style.display = 'block'
        }

        if (!isBtnContainer) {
            content.message.style.paddingBottom = '20px'
            content.actions.style.display = 'none'
        }
    }

    formatDate(date) {
        let data = {
            month : dateDict.month[date.getUTCMonth()],
            day : date.getUTCDate(),
            year : date.getUTCFullYear(),
            hours : dateDict.hours[date.getUTCHours()][0],
            hours2 : dateDict.hours[date.getUTCHours()][1],
            minutes : date.getUTCMinutes(),
        }
        return data.month + ' ' + data.day + ', ' + data.year + ' ' + data.hours + ':' + data.minutes + ' ' + data.hours2
    }

}

// Showing and creating annonuces

Rev.func.show.announces = function(data) {
    document.getElementById('announce-header').innerHTML = "("+ data.length +"/20)"
    document.getElementById('announce-header-wrapper').style.display = 'block'
    document.getElementById('announces-wrapper').innerHTML = ''

    if (data.length == 0) {
        Rev.func.emptyBox('Nema obavestenja')
        return
    }

    data.sort(function(a,b) {
        return new Date(b[3]) - new Date(a[3])
    });

    data.forEach(val => {
        new Announce(val[0], val[1], val[2], new Date(val[3]), val[4]).create()
    });
}


// Announces Clear
Rev.func.clear.announces = function() {
    document.getElementById('announce-header-wrapper').style.display = 'none'
    document.getElementById('announces-wrapper').innerHTML = ''
}


// Announce Methods

Rev.func.newAnnounce = function(title, message) {
    let data = [
        Rev.func.getPlayerName(),
        title,
        message, 
        Date.now(),
        generateUUID()
    ]
    Rev.func.clear.announceInput()
    Rev.Announces.push(data)
    Rev.func.toLua('sendAnnounce', data)
    Rev.func.show.announces(Rev.Announces)
}

Rev.func.deleteAnnounce = function(uuid) {
    for(let i = 0; i < Rev.Announces.length; i++){ 
        if (Rev.Announces[i][4] == uuid) { 
            Rev.Announces.splice(i, 1); 
            Rev.func.clear.announceInput()
            Rev.func.toLua('deleteAnnounce', {uuid : uuid})        
            Rev.func.show.announces(Rev.Announces)
            return
        }
    }
}

Rev.func.editAnnounce = function(uuid, title, message) {
    for(let i = 0; i < Rev.Announces.length; i++){ 
        if (Rev.Announces[i][4] == uuid) { 
            let data = [
                Rev.func.getPlayerName(),
                title,
                message, 
                Date.now(),
                generateUUID()
            ]
            Rev.func.clear.announceInput()
            Rev.Announces[i] = data
            Rev.func.toLua('editAnnounce', {uuid : uuid, message : data[2]})
            Rev.func.show.announces(Rev.Announces)
            return
        }
    }
}

//https://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid

function generateUUID() { // Public Domain/MIT
    var d = new Date().getTime();//Timestamp
    var d2 = ((typeof performance !== 'undefined') && performance.now && (performance.now()*1000)) || 0;//Time in microseconds since page-load or 0 if unsupported
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16;//random number between 0 and 16
        if(d > 0){//Use timestamp until depleted
            r = (d + r)%16 | 0;
            d = Math.floor(d/16);
        } else {//Use microseconds since page-load if supported
            r = (d2 + r)%16 | 0;
            d2 = Math.floor(d2/16);
        }
        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
    });
}

