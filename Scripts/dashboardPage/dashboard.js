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

    activeAccountId = Number(activeCard.dataset.accountId);

    // TEMP debug
    console.log("Active account:", activeAccountId);

    // Hook analytics refresh here
    updateAnalytics(activeAccountId);
    refreshTransactions(activeAccountId);
    updateIncome(activeAccountId)
}

//TRANSACTIONS
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


/*const TRANSACTIONS_BY_ACCOUNT = {
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
*/



//Touch this one when swapping to database
function refreshTransactions(accountId) {
    /*const data = TRANSACTIONS_BY_ACCOUNT[accountId] || [];
    renderTransactions(data);
    */

    fetch(`/api/transactions?accountId=${accountId}`)
        .then(res => {
            if (!res.ok) throw new Error("Failed to load transactions");
            return res.json();
        })
        .then(renderTransactions)
        .catch(err => {
            console.error(err);
            renderTransactions([]);
        });


}

//CHARTS 

function updateAnalytics(accountId) {
    console.log("Fetching analytics for", accountId);

    fetch(`/api/expenses/summary?accountId=${accountId}`)
        .then(res => res.json())
        .then(data => {
            renderChart(
                data.map(d => d.label),
                data.map(d => d.value)
            );
        });


    /*
    const fakeData = {
        1: [120, 80, 150, 90],
        2: [60, 40, 30, 20],
        3: [300, 120, 60, 10]
    };
    */
}

let chartInstance = null;

function renderChart(labels, values) {
    const ctx = document.getElementById("expensesChart");
    if (!ctx) return;

    chartInstance?.destroy();

    chartInstance = new Chart(ctx, {
        type: "bar",
        data: {
            labels,
            datasets: [{
                data: values,
                backgroundColor: "#60a5fa"
            }]
        }
    });
}


let incomeChartInstance = null;

function updateIncome(accountId) {
    /*
    const fakeIncomeData = {
        1: [800, 300, 100],
        2: [500, 200],
        3: [1200]
    };
    */

    fetch(`/api/income/summary?accountId=${accountId}`)
        .then(res => res.json())
        .then(data => {
            incomeChartInstance?.destroy();
            incomeChartInstance = new Chart(
                document.getElementById("incomeChart"),
                {
                    type: "bar",
                    data: {
                        labels: data.map(d => d.label),
                        datasets: [{
                            data: data.map(d => d.value),
                            backgroundColor: "#4ade80"
                        }]
                    },
                    options: { plugins: { legend: { display: false } } }
                }
            );
        });
}
