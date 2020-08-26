document.querySelectorAll('.first a')[0].onclick = function() { //bouton au mois
    document.querySelector('.first .screen').classList.remove('bg-agenda-jour');
    document.querySelector('.first .screen').classList.add('bg-agenda-mois');
}

document.querySelectorAll('.first a')[1].onclick = function() { //bouton au jour
    document.querySelector('.first .screen').classList.remove('bg-agenda-mois');
    document.querySelector('.first .screen').classList.add('bg-agenda-jour');
}
