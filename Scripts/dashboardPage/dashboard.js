let currentIndex = 0;
const DEV_STATIC_TRANSACTIONS = true;

document.addEventListener("DOMContentLoaded", () => {
    syncCardRoles();
    updateActiveAccount();

    console.log("before pagination");
    initPagination();
    syncPagination();
    console.log("after pagination");

    document
        .querySelector(".cards-stack")
        .addEventListener("click", rotateCards);
});


function rotateCards() {
    const stack = document.querySelector(".cards-stack");
    const cards = Array.from(stack.children);

    if (cards.length < 2) return;

    stack.appendChild(cards[0]);

    currentIndex = (currentIndex + 1) % cards.length;

    syncCardRoles();
    syncPagination();
    updateActiveAccount();
}

function syncCardRoles() {
    const cards = document.querySelectorAll(".bank-card");
    cards.forEach(c => c.classList.remove("is-active", "is-back", "is-back-2"));

    if (cards[0]) cards[0].classList.add("is-active");
    if (cards[1]) cards[1].classList.add("is-back");
    if (cards[2]) cards[2].classList.add("is-back-2");

}

//Pagination dot stuff
function initPagination() {
    const stack = document.querySelector(".cards-stack");
    const pagination = document.querySelector(".card-pagination");
    if (!stack || !pagination) return;

    const cards = stack.querySelectorAll(".bank-card");

    pagination.innerHTML = "";

    cards.forEach(() => {
        const dot = document.createElement("span");
        dot.classList.add("dot");
        pagination.appendChild(dot);
    });
}

function syncPagination() {
    const dots = document.querySelectorAll(".card-pagination .dot");
    dots.forEach(d => d.classList.remove("is-active"));

    if (dots[currentIndex]) {
        dots[currentIndex].classList.add("is-active");
    }
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
    updateIncome(activeAccountId)
}

function updateTransactions(accountId) {
    if (DEV_STATIC_TRANSACTIONS) {
        console.log("Skipping JS transaction render (static UI mode)");
        return;
    }
    const container = document.querySelector(".widget-transactions");
    const fakeTransactions = {
        1: [
            { label: "Food", amount: 20 },
            { label: "Transport", amount: 5 },
            { label: "Shopping", amount: 40 }
        ],
        2: [
            { label: "Food", amount: 10 },
            { label: "Bills", amount: 30 }
        ],
        3: [
            { label: "Shopping", amount: 15 }
        ]
    };

    const transactions = fakeTransactions[accountId] || [];


    if (transactions.length === 0) {
        container.innerHTML = `
            <h4>Transactions</h4>
            <p>No transactions</p>
        `;
        return;
    }

    const items = transactions
        .map(t => `<li>${t.label} : $${t.amount}</li>`)
        .join("");

    container.innerHTML = `
        <h4>Transactions</h4>
        <ul>${items}</ul>
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

let incomeChartInstance = null;

function updateIncome(accountId) {
    const fakeIncomeData = {
        1: [800, 300, 100],
        2: [500, 200],
        3: [1200]
    };
    const data = fakeIncomeData[accountId] || [];

    const ctx = document.getElementById("incomeChart");
    if (!ctx) return;

    if (incomeChartInstance) {
        incomeChartInstance.destroy();
    }

    incomeChartInstance = new Chart(ctx, {
        type: "bar",
        data: {
            labels: data.map((_, i) => `Source ${i + 1}`),
            datasets: [{
                label: "Income",
                data,
                backgroundColor: "#4ade80"
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            }
        }
    });
}
