Rev.func.navigation.menu = function(page) {
    if (Rev.State.MenuPage == page) return

    Rev.func.clear[Rev.State.MenuPage]()
    Rev.func.show[page]()

    Rev.State.MenuPage = page
}

// Home

Rev.func.show.home = function() {
    document.getElementById('home').style.display = 'block'
    Rev.func.show.announces(Rev.Announces)
    Rev.func.show.teritoriesRanked(Rev.RankList)
    Rev.func.show.menuItem('home')
}

Rev.func.clear.home = function() {
    document.getElementById('home').style.display = 'none'
    Rev.func.clear.announces()
    Rev.func.clear.allTeritories()
    Rev.func.clear.menuItem('home')
}

Rev.func.initHome = function(data) {
    if (typeof data == 'undefined') return

    document.getElementById('character_name').innerHTML = Rev.func.getPlayerName() + ' <span class="font-darker" id="grade_label"></span>'
    for (var i in data) {
        if (data[i].sidebar) document.getElementById(i).innerHTML = data[i].result
    }
}

// Skills
Rev.func.show.skills = function() {
    document.getElementById('skills').style.display = 'block'
    Rev.func.show.menuItem('skills')
}

Rev.func.clear.skills = function() {
    document.getElementById('skills').style.display = 'none'
    Rev.func.clear.menuItem('skills')
}

// Members
Rev.func.show.members = function() {
    document.getElementById('members').style.display = 'block'
    Rev.func.show.menuItem('members')
}

Rev.func.clear.members = function() {
    document.getElementById('members').style.display = 'none'
    Rev.func.clear.menuItem('members')
}

//All
Rev.func.DefaultState = function() {
    Rev.State.MenuPage = 'home'
    Rev.State.TeritoryPage = 'teritoriesRanked'
}

Rev.func.clear.all = function() {
    // Clearing all pages
    Rev.func.clear.home()
    Rev.func.clear.skills()
    Rev.func.clear.teritories()
    Rev.func.clear.members()
    Rev.func.clear.announceInput()
    Rev.func.teritoriesMenu('teritoriesRanked')
    // Setting default states
    Rev.func.DefaultState()
    // Adding active menu Item to default state of Menu Page
    Rev.func.show.menuItem('home')
}

// Change Navbar behavior

Rev.func.clear.menuItem = function(page) {
    document.getElementById('menu-' + page).classList.remove('menu-focus') 
    document.getElementById('btn-' + page).classList.remove('font-light', 'font-bold') 
    document.getElementById('btn-' + page).classList.add('font-dark') 
}

Rev.func.show.menuItem = function(page) {
    document.getElementById('menu-' + page).classList.add('menu-focus') 
    document.getElementById('btn-' + page).classList.add('font-light', 'font-bold') 
    document.getElementById('btn-' + page).classList.remove('font-dark') 
}


// Info functions
Rev.func.getPlayerName = function() {
    let playerData = Rev.Player.personal.result
    return playerData.firstname + " " + playerData.lastname
} 

// Some functions

Rev.func.closeTablet = function() {
    Rev.func.clear.all()
    Rev.func.toLua('close', JSON.stringify())
}

Rev.func.toLua = function(endpoint, data) {
    fetch('http://' + Rev.resourceName + '/' + endpoint, {
        method: "POST",
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
      }).then(res => {});
}

Rev.func.emptyBox = function(txt) {
    let box = document.createElement('div')
    box.classList.add('announce-box');

    let text = document.createElement('p')
    text.classList.add('font-bold', 'font-dark', 'small-txt', 'py-3')
    text.innerHTML = txt
    let wrapper = document.getElementById('announces-wrapper')
    box.appendChild(text)
    wrapper.appendChild(box)
}
