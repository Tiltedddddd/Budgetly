document.addEventListener("DOMContentLoaded", () => {
    const stack = document.querySelector(".cards-stack");

    syncCardRoles();
    updateActiveAccount();

    document
        .querySelector(".cards-stack")
        .addEventListener("click", rotateCards);
});

function rotateCards() {
    const stack = document.querySelector(".cards-stack");
    const cards = Array.from(stack.children);

    if (cards.length < 2) return;

    stack.appendChild(cards[0]);
    syncCardRoles();
    updateActiveAccount();
}

function syncCardRoles() {
    const cards = document.querySelectorAll(".bank-card");
    cards.forEach(c => c.classList.remove("is-active", "is-back", "is-back-2"));

    if (cards[0]) cards[0].classList.add("is-active");
    if (cards[1]) cards[1].classList.add("is-back");
    if (cards[2]) cards[2].classList.add("is-back-2");
}

//STUFF THAT UPDATE BASED ON WHICH ACCOUNT IS SELECTED
let activeAccountId = null;

function updateActiveAccount() {
    const activeCard = document.querySelector(".bank-card.is-active");
    if (!activeCard) return;

    activeAccountId = activeCard.dataset.accountId;

    // TEMP debug
    console.log("Active account:", activeAccountId);

    // Hook analytics refresh here
    updateAnalytics(activeAccountId);
    updateTransactions(activeAccountId);
}

function updateTransactions(accountId) {
    const el = document.querySelector(".widget-transactions");
    el.innerHTML = `
    <h4>Transactions</h4>
    <ul>
      <li>Food – $20</li>
      <li>Transport – $5</li>
      <li>Shopping – $40</li>
    </ul>
  `;
}



function updateAnalytics(accountId) {
    console.log("Fetching analytics for", accountId);

    const fakeData = {
        1: [120, 80, 150, 90],
        2: [60, 40, 30, 20],
        3: [300, 120, 60, 10]
    };

    renderChart(fakeData[accountId]);
}

let chartInstance = null;

function renderChart(data) {
    const ctx = document.getElementById("expensesChart");

    if (chartInstance) {
        chartInstance.destroy();
    }

    chartInstance = new Chart(ctx, {
        type: "bar",
        data: {
            labels: ["Food", "Transport", "Shopping", "Bills"],
            datasets: [{
                data,
                backgroundColor: "#60a5fa"
            }]
        }
    });
}

function updateIncome(accountId) {
    document.querySelector(".widget-income").innerHTML = `
    <h4>Income</h4>
    <p>$1,200 this month</p>
  `;
}
