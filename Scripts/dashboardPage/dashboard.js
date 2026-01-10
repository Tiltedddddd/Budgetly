let currentIndex = 0;

document.addEventListener("DOMContentLoaded", () => {
    syncCardRoles();

    initPagination();
    syncPagination();

    updateActiveAccount();


    document
        .querySelector(".cards-stack")
        ?.addEventListener("click", rotateCards);
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


//DYNAMIC WIDGET UPDATES FOR THINGS THAT SHOULD CHANGE WITH ACCOUNTS

let activeAccountId = null;

function updateActiveAccount() {
    const activeCard = document.querySelector(".bank-card.is-active");
    if (!activeCard) return;

    activeAccountId = activeCard.dataset.accountId;

    // TEMP debug
    console.log("Active account:", activeAccountId);

    // Hook analytics refresh here
    updateAnalytics(activeAccountId);
    refreshTransactions(activeAccountId);
    updateIncome(activeAccountId)
}


function renderTransactions(data) {
    const list = document.getElementById("transactionsList");
    if (!list) return;

    list.innerHTML = "";

    if (data.length === 0) {
        list.innerHTML = `
            <li class="transaction-item empty">
                <span>No transactions for this account</span>
            </li>
        `;
        return;
    }

    data.forEach(tx => {
        const isIncome = tx.amount > 0;

        const li = document.createElement("li");
        li.className = "transaction-item";

        li.innerHTML = `
            <img src="${tx.icon}" class="tx-icon" />
            <div class="tx-info">
                <span class="tx-merchant">${tx.merchant}</span>
                <span class="tx-category">${tx.category}</span>
            </div>
            <span class="tx-amount ${isIncome ? "positive" : "negative"}">
                ${isIncome ? "+" : "-"}$${Math.abs(tx.amount).toFixed(2)}
            </span>
        `;

        list.appendChild(li);
    });
}


const TRANSACTIONS_BY_ACCOUNT = {
    1: [
        {
            merchant: "Grab Transport",
            category: "Transportation",
            amount: -10,
            icon: "../Content/images/icons/grabLogo.png"
        }
    ],
    2: [
        {
            merchant: "Grab Transport co.",
            category: "Transportation",
            amount: -10.00,
            icon: "../Content/images/icons/grabLogo.png"
        },
        {
            merchant: "PayNow - John Pork",
            category: "Payment",
            amount: 5.00,
            icon: "../Content/images/icons/paynowLogo.png"
        },
    ],
    3: [
        {
            merchant: "Grab Transport co.",
            category: "Transportation",
            amount: -10.00,
            icon: "../Content/images/icons/grabLogo.png"
        },
        {
            merchant: "PayNow - John Pork",
            category: "Payment",
            amount: 5.00,
            icon: "../Content/images/icons/paynowLogo.png"
        },
        {
            merchant: "PayNow - Javier Jesus",
            category: "Payment",
            amount: 50.00,
            icon: "../Content/images/icons/paynowLogo.png"
        },
        {
            merchant: "PayNow - Mother",
            category: "Payment",
            amount: 500.00,
            icon: "../Content/images/icons/paynowLogo.png"
        },
        {
            merchant: "Grab Transport co.",
            category: "F&B",
            amount: -25.00,
            icon: "../Content/images/icons/grabLogo.png"
        }
    ]
};


//Touch this one when swapping to database
function refreshTransactions(accountId) {
    const data = TRANSACTIONS_BY_ACCOUNT[accountId] || [];
    renderTransactions(data);

    // later (real DB)
    // fetch(`/api/transactions?accountId=${accountId}`)
    //   .then(res => res.json())
    //   .then(renderTransactions);
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
