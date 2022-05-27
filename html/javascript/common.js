var Rev = {}
Rev.resourceName = 'revolucija_organizacije2'

Rev.Config = {}
Rev.func = {}
Rev.func.show = {}
Rev.func.clear = {}
Rev.func.navigation = {}
Rev.func.navigation.menu = {}

Rev.RankList = {}
Rev.Player = {}
Rev.State = {
    MenuPage : 'home',
    TeritoryPage : 'teritoriesRanked'
}

Rev.Announces = {}

Rev.Wrappers = {}
Rev.Wrappers.home = {}
Rev.Wrappers.home.announces = document.querySelector('#announces-wrapper')
Rev.Wrappers.home.firstCol = document.querySelector('#first-column')
Rev.Wrappers.home.secondCol = document.querySelector('#second-column')
Rev.Wrappers.home.teritories = document.querySelector('#teritories')
Rev.Wrappers.home.teritoriesRanked = document.querySelector('#teritories-ranked')
Rev.Wrappers.home.tablet = document.querySelector('#tablet')
