-- Fund App Database Initialization Script

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(11) UNIQUE,
    id_card VARCHAR(18) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(32) NOT NULL,
    user_type VARCHAR(20) DEFAULT 'direct_sales',
    risk_level VARCHAR(10),
    risk_expire_date DATETIME,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_device VARCHAR(100),
    last_login_ip VARCHAR(45),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create funds table
CREATE TABLE IF NOT EXISTS funds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fund_code VARCHAR(10) UNIQUE NOT NULL,
    fund_name VARCHAR(100) NOT NULL,
    fund_type VARCHAR(20) NOT NULL,
    risk_level VARCHAR(10) NOT NULL,
    nav DECIMAL(10, 4) NOT NULL,
    acc_nav DECIMAL(10, 4) NOT NULL,
    min_purchase DECIMAL(10, 2) DEFAULT 100.00,
    min_switch DECIMAL(10, 2) DEFAULT 100.00,
    purchase_fee DECIMAL(5, 4) DEFAULT 0.015,
    redeem_fee DECIMAL(5, 4) DEFAULT 0.005,
    manager_name VARCHAR(50),
    company_name VARCHAR(100),
    description TEXT,
    status VARCHAR(20) DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create fund_nav_history table
CREATE TABLE IF NOT EXISTS fund_nav_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fund_code VARCHAR(10) NOT NULL,
    nav_date DATETIME NOT NULL,
    nav DECIMAL(10, 4) NOT NULL,
    acc_nav DECIMAL(10, 4) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_fund_code (fund_code),
    INDEX idx_nav_date (nav_date)
);

-- Create fund_profiles table
CREATE TABLE IF NOT EXISTS fund_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fund_code VARCHAR(10) NOT NULL,
    holding_stock_code VARCHAR(10),
    holding_stock_name VARCHAR(100),
    holding_ratio DECIMAL(5, 4),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_fund_code (fund_code)
);

-- Create portfolios table
CREATE TABLE IF NOT EXISTS portfolios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    portfolio_name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);

-- Create portfolio_positions table
CREATE TABLE IF NOT EXISTS portfolio_positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id INT NOT NULL,
    fund_code VARCHAR(10) NOT NULL,
    fund_name VARCHAR(100) NOT NULL,
    target_ratio DECIMAL(5, 4) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0.00,
    current_shares DECIMAL(15, 4) DEFAULT 0.00,
    nav DECIMAL(10, 4) DEFAULT 1.0000,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_portfolio_id (portfolio_id)
);

-- Create trade_orders table
CREATE TABLE IF NOT EXISTS trade_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    fund_code VARCHAR(10) NOT NULL,
    fund_name VARCHAR(100) NOT NULL,
    trade_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    shares DECIMAL(15, 4),
    nav DECIMAL(10, 4),
    fee DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'pending',
    pay_method VARCHAR(20) NOT NULL,
    target_fund_code VARCHAR(10),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    confirmed_at DATETIME,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_fund_code (fund_code),
    INDEX idx_trade_type (trade_type)
);

-- Create wallets table
CREATE TABLE IF NOT EXISTS wallets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    balance DECIMAL(15, 2) DEFAULT 0.00,
    frozen_balance DECIMAL(15, 2) DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);

-- Create wallet_transactions table
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    wallet_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'completed',
    remark VARCHAR(200),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_wallet_id (wallet_id)
);

-- Create bank_cards table
CREATE TABLE IF NOT EXISTS bank_cards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    bank_name VARCHAR(50) NOT NULL,
    bank_code VARCHAR(20) NOT NULL,
    card_number VARCHAR(30) NOT NULL,
    card_type VARCHAR(20) DEFAULT '储蓄卡',
    is_default BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);

-- Create accounts table
CREATE TABLE IF NOT EXISTS accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    id_card VARCHAR(18) NOT NULL,
    id_card_type VARCHAR(10) DEFAULT 'id_card',
    real_name VARCHAR(50) NOT NULL,
    id_card_expire DATE NOT NULL,
    risk_level VARCHAR(10),
    risk_expire_date DATE,
    risk_status VARCHAR(20) DEFAULT 'not_done',
    account_status VARCHAR(20) DEFAULT 'pending',
    verification_status VARCHAR(20) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);

-- Create risk_questionnaires table
CREATE TABLE IF NOT EXISTS risk_questionnaires (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    answers TEXT,
    score INT DEFAULT 0,
    risk_level VARCHAR(10),
    expire_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);

-- Insert mock funds
INSERT INTO funds (fund_code, fund_name, fund_type, risk_level, nav, acc_nav, min_purchase, purchase_fee, redeem_fee, manager_name, company_name, description) VALUES
('000001', '货币基金A', 'money_market', 'R1', 1.0000, 1.0000, 100.00, 0.0000, 0.0000, '张经理', '华夏基金', '货币市场基金，主要投资短期银行存款、央行票据等低风险品种'),
('000002', '股票基金B', 'stock', 'R5', 2.5000, 3.2000, 1000.00, 0.0150, 0.0050, '李经理', '易方达基金', '股票型基金，主要投资A股市场，追求长期资本增值'),
('000003', '混合基金C', 'hybrid', 'R3', 1.8000, 2.1000, 500.00, 0.0120, 0.0030, '王经理', '嘉实基金', '混合型基金，股债平衡配置，追求稳健收益'),
('000004', 'FOF基金D', 'fof', 'R4', 1.2000, 1.4500, 1000.00, 0.0100, 0.0025, '赵经理', '南方基金', '基金中基金，主要投资于其他开放式基金，分散风险');