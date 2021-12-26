var main = document.querySelector('#input-container')


// Announce Inputs
Rev.func.show.announceInput = function(edit) {
    
    // Let's validate inputs
    function validate(title, message) {
        if (title.length < 8) {
            return 'Naziv obavestenja mora imati minimalno 8 karaktera'
        } else if(message.length < 10) {
            return 'Poruka mora imati minimalno 10 karaktera'
        } else if (message.length > 371) {
            return 'Prevrsili ste limit karaktera (371) u poruci'
        } else if (Rev.Announces.length > 20) {
            return 'Prevrsili ste limit obavestenja'
        }

        return ''
    }

    // Let's reveal
    Rev.func.show.inputContainer()

    // Let's build data of elements
    let data = {
        content : document.createElement('div'),
        title : document.createElement('h1'),
        error : document.createElement('span'),
        input : document.createElement('input'),
        textarea : document.createElement('textarea'),
        button : document.createElement('button'),
        secondaryButton : document.createElement('button')
    }
    // Passing data and adding classes
    data.button.classList.add('primary-btn')
    data.secondaryButton.classList.add('secondary-btn')
    data.error.classList.add('font-red', 'very-small-txt')

    if (!edit) {
        data.title.innerHTML = 'Napisite novo obavestenje',
        data.input.placeholder = 'Naziv obavestenja'
        data.textarea.placeholder = 'Poruka'
        data.button.innerHTML = 'Objavite obavestenje'    
    } else {
        data.title.innerHTML = 'Uredite obavestenje',
        data.input.value = edit.title
        data.textarea.value = edit.message
        data.button.innerHTML = 'Uredite obavestenje'   
        data.secondaryButton.innerHTML = 'Obrisi obavestenje' 
    }

    // Adding methods
    data.button.onclick = function() {
        let status = validate(data.input.value, data.textarea.value)

        if (status == '') {
            if (!edit) Rev.func.newAnnounce(data.input.value, data.textarea.value)
            else Rev.func.editAnnounce(edit.uuid, data.input.value, data.textarea.value)
            return
        }
        
        data.error.innerHTML = "<br>" + status
    }

    if (edit) {
        data.secondaryButton.onclick = function() {
            Rev.func.deleteAnnounce(edit.uuid)
        }
    }

    // Building inner content
    data.title.appendChild(data.error)

    // Building main content
    data.content.appendChild(data.title)
    data.content.appendChild(data.input)
    data.content.appendChild(data.textarea)
    if (edit) data.content.appendChild(data.secondaryButton)
    data.content.appendChild(data.button)

    setTimeout(() => {
        main.appendChild(data.content)
    }, 500);
}


Rev.func.clear.announceInput = function() {
    let main = document.getElementById('input-container')
    main.innerHTML = ''
    main.style.display = 'none'
}

//Donate input 
Rev.func.show.donateMoney = function() {
    Rev.func.show.inputContainer()
    // Building elements
    let data = {
        content : document.createElement('div'),
        title : document.createElement('h1'),
        button : document.createElement('button'),
        input : document.createElement('input'),
        range : document.createElement('input'),
        notice : document.createElement('span'),
    }

    // Passing data to elements
    data.title.innerHTML = 'Donirajte 0$',
    data.button.innerHTML = 'Donirajte novac' 
    data.button.classList.add('primary-btn')
    data.title.classList.add('text-center')
    data.notice.innerHTML = 'Pare se mogu koristiti za kupovinu ilegalnih stvari, unapredjivanje organizacije i otkljucavanje vestina. Pare ne mozete podici!'
    data.notice.classList.add('font-red', 'very-small-txt', 'my-2', 'text-center')

    data.range.type = 'range'
    data.range.min = 0
    data.range.max = Rev.Player.personalMoney.result
    data.range.value = 0
    data.input.value = 0

    data.input.oninput = function() {
        if (this.value <= Rev.Player.personalMoney.result) {
            data.title.innerHTML = 'Donirajte ' + this.value + '$';
            data.range.value = this.value
        } else {
            data.input.value = Rev.Player.personalMoney.result
        }
    }

    data.range.oninput = function() {
        data.title.innerHTML = 'Donirajte ' + this.value + '$';
        data.input.value = this.value
    }

    data.button.onclick = function() {
        let money = parseInt(document.getElementById('money').innerHTML) + parseInt(data.input.value)
        let yourMoney = parseInt(data.input.value)
        document.getElementById('money').innerHTML = money
        Rev.func.toLua('donateMoney', {money : yourMoney})
        Rev.Player.personalMoney.result -= yourMoney
        Rev.func.clear.inputContainer()
    }

    data.content.appendChild(data.title)
    data.content.appendChild(data.range)
    data.content.appendChild(data.input)
    data.content.appendChild(data.button)
    data.content.appendChild(data.notice)

    setTimeout(() => {
        main.appendChild(data.content)
    }, 500);

}

//Input utilis

Rev.func.show.inputContainer = function() {
    main.innerHTML = ''
    main.style.display = 'flex'
    Rev.func.createCloseButton(main)
    main.appendChild(Rev.func.createCloseButton(main))
}

Rev.func.clear.inputContainer = function() {
    let main = document.getElementById('input-container')
    main.innerHTML = ''
    main.style.display = 'none'
}

Rev.func.createCloseButton = function(main) {
    let closeButton = document.createElement('button')
    closeButton.innerHTML = 'Izadji'
    closeButton.classList.add('close-input')

    closeButton.onclick = function() {
        main.innerHTML = ''
        main.style.display = 'none'
    }

    return closeButton
}