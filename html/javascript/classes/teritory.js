class Teritory {
    constructor(owner, ownerLabel, label, cooldown, description, background) {
        this.owner = owner
        this.owner_label = ownerLabel
        this.label = label
        this.cooldown = cooldown,
        this.description = description
        this.background = background
    }

    create() {
        // Creating Elements
        let box = document.createElement('div')
        let title = document.createElement('h1')
        let cooldown = document.createElement('p')
        let description = document.createElement('p')

        // Styling Elements
        box.classList.add('item')

        if (Rev.Player.job == this.owner) box.style.background = 'rgba(0, 64, 255, 0.64)'
        box.style.backgroundImage = 'url(./images/' + this.background + ')'

        // Passing Data to elements
        title.innerHTML = this.label + '<span class="mx-2">' + this.owner + '</span>'
        cooldown.innerHTML = 'Cooldown: ' + this.formatCooldown(this.cooldown)
        description.innerHTML = this.description 

        // Building elements
        box.appendChild(title)
        box.appendChild(cooldown)
        box.appendChild(description)
        Rev.Wrappers.home.teritories.appendChild(box)
    }

    formatCooldown(future) {
        let now = new Date(1639979746);
        let totalSeconds = Math.abs(future - now) / 1000; 
        let hours = Math.floor(totalSeconds / 3600) % 24;
        totalSeconds -= hours * 3600
        let minutes = Math.floor(totalSeconds / 60) % 60;
        if (hours > 0) {
            return hours + 'h ' + minutes + 'min' 
        } else if (hours <= 0 && minutes > 0) {
            return minutes + 'min' 
        } else return 'Nema'
    }
}

class RankList {
    constructor(rank, owner, label, points) {
        this.rank = rank
        this.owner = owner
        this.label = label
        this.points = points
    }

    create() {
        let content = document.getElementById('rank-list')
        // Setting ranked header
        if (this.owner == Rev.Player.job_name.result) {
            document.getElementById('rank-org-name').innerHTML = this.label
            document.getElementById('rank-org-points').innerHTML = "#" + this.rank + ", " + this.points + " bodova"
        }

        // Building elements
        let box = document.createElement('div')
        let rank = document.createElement('p')
        let image = document.createElement('img')
        let org = document.createElement('h1')
        let points = document.createElement('h2')
        // Adding classes
        box.classList.add('rank-list')
        rank.classList.add('small-txt', 'mx-2')
        org.classList.add('small-txt', 'mx-2')
        points.classList.add('small-txt', 'mx-2')
        //Passing Data
        if (this.rank == 1) image.src = './images/first-cup.png'
        else if (this.rank == 2) image.src = './images/second-cup.png'
        else if (this.rank == 3) image.src = './images/third-cup.png'
        else image.src = './images/other-cup.png'

        rank.innerHTML = '#' + this.rank
        org.innerHTML = this.label
        points.innerHTML = this.points + " bodova"
        // Appending
        box.append(rank, image, org, points)

        content.append(box)
    }
}


// Navigation

Rev.func.navigation.teritories = function(page) {
    if (Rev.State.TeritoryPage == page) return

    Rev.func.teritoriesMenu(page)
    Rev.func.clear[Rev.State.TeritoryPage]()
    Rev.func.show[page]()

    Rev.State.TeritoryPage = page
}


//show

Rev.func.teritoriesMenu = function(page) {
    if (Rev.State.TeritoryPage == page) return

    document.getElementById('btn-' + Rev.State.TeritoryPage).classList.remove('header-btn-focus')
    document.getElementById('btn-' + Rev.State.TeritoryPage).classList.add('header-btn')

    document.getElementById('btn-' + page).classList.remove('header-btn')
    document.getElementById('btn-' + page).classList.add('header-btn-focus')
}

Rev.func.show.teritories = function() {
    document.getElementById('teritories').style.display = 'block';


    let end = document.createElement('p')
    end.innerHTML = '<p class="very-small-txt font-dark text-center my-2">Kraj teritorija</p>'
    teritories.appendChild(end)
}

Rev.func.clear.allTeritories = function() {
    Rev.func.clear.teritories()
    Rev.func.clear.teritoriesRanked()
    Rev.func.clear.teritoriesRules()
}

Rev.func.show.allTeritories = function() {
    Rev.func.show.teritories()
}

Rev.func.show.teritoriesRanked = function() {
    document.getElementById('teritories-ranked').style.display = 'block';
    Rev.func.show.teritoryRanks(Rev.RankList)
}

Rev.func.show.teritoriesRules = function() {
    document.getElementById('teritories-rules').style.display = 'block';
}

//Clear

Rev.func.clear.teritories = function() {
    document.getElementById('teritories').style.display = 'none';
    document.getElementById('teritories').innerHTML = ''
}

Rev.func.clear.teritoriesRanked = function() {
    document.getElementById('teritories-ranked').style.display = 'none'
    document.getElementById('rank-list').innerHTML = ''
}

Rev.func.clear.teritoriesRules = function() {
    document.getElementById('teritories-rules').style.display = 'none';
}

//Rank list

Rev.func.show.teritoryRanks = function(data) {  
    // Let's make object an array and sort it
    let array = []
    
    for (var i in data) {
        if (typeof Rev.Config.Org.list[i] !== 'undefined') {
            let org = Rev.Config.Org.list[i]
            if (org.type == 'mafia' || org.type == 'hood') {
                array.push([i, data[i]])
            }
        }
    }

    function compareNumbers(a, b) {
        return b[1].elo - a[1].elo;
    }

    array.sort(compareNumbers)
    
    // Let's create 
    for (let i = 0; i < array.length; i++) {
        new RankList(i + 1, array[i][0], array[i][1].label, array[i][1].elo).create()      
    }
}