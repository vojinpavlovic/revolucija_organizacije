--[[ Adding Global variables ]]--

ESX = nil
Rev = {}
Rev.table = {}
Rev.Save = {}
Rev.org = {
    jobs = {},
    func = {}
}
Rev.teritories = {
    rang = {},
    func = {},
    instances = {}
}

Rev.rankList = {}
GlobalState.rankList = {}

--[[ Loading Framework ]]--

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

