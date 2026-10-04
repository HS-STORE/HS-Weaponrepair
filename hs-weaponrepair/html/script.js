window.addEventListener('message', function (event) {
    let data = event.data;
    if (data.action === "open") {
        document.getElementById('repair-cost').innerText = "$" + data.price.toLocaleString();
        
        
        let weaponImageSrc = `nui://qb-inventory/html/images/${data.weapon}.png`;
        document.getElementById('weapon-img').src = weaponImageSrc;

        document.getElementById('repair-container').classList.remove('hidden');
    } else if (data.action === "close") {
        closeMenu();
    }
});

function closeMenu() {
    document.getElementById('repair-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
}

document.getElementById('close-btn').addEventListener('click', closeMenu);

document.getElementById('repair-btn').addEventListener('click', function () {
    fetch(`https://${GetParentResourceName()}/confirmRepair`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.onkeyup = function (data) {
    if (data.which == 27) {
        closeMenu();
    }
};