-- =========================================================
-- ELIMUBUDDY AI
-- MASTER SUPABASE SCHEMA (MIGRATIONS 001 - 040)
-- CONSOLIDATED PRODUCTION BACKEND
-- =========================================================

-- WARNING:
-- This is a consolidated master schema combining:
-- - Reconstructed core architecture (001–033)
-- - Exact implemented migrations (034–040)

-- =========================================================
-- CORE SYSTEM FOUNDATION (001 - 033 RECONSTRUCTED)
-- =========================================================

CREATE SCHEMA IF NOT EXISTS auth_system;
CREATE SCHEMA IF NOT EXISTS schools;
CREATE SCHEMA IF NOT EXISTS curriculum;
CREATE SCHEMA IF NOT EXISTS learning;
CREATE SCHEMA IF NOT EXISTS ai_personalization;
CREATE SCHEMA IF NOT EXISTS gamification;
CREATE SCHEMA IF NOT EXISTS community;
CREATE SCHEMA IF NOT EXISTS analytics;

-- -------------------------
-- AUTH SYSTEM
-- -------------------------
CREATE TABLE auth_system.profiles (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    role TEXT,
    country TEXT,
    language TEXT,
    timezone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE auth_system.user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    role TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE auth_system.permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role TEXT,
    permission TEXT
);

-- -------------------------
-- SCHOOLS MODULE
-- -------------------------
CREATE TABLE schools.schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    country TEXT,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE schools.students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    school_id UUID REFERENCES schools.schools(id),
    class TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE schools.teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    school_id UUID REFERENCES schools.schools(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------
-- CURRICULUM (CBC CORE)
-- -------------------------
CREATE TABLE curriculum.subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    grade_level TEXT
);

CREATE TABLE curriculum.strands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID REFERENCES curriculum.subjects(id),
    name TEXT
);

CREATE TABLE curriculum.sub_strands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    strand_id UUID REFERENCES curriculum.strands(id),
    name TEXT
);

-- -------------------------
-- LEARNING ENGINE
-- -------------------------
CREATE TABLE learning.lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sub_strand_id UUID,
    title TEXT,
    content TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE learning.learning_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES schools.students(id),
    lesson_id UUID,
    progress NUMERIC(5,2),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- -------------------------
-- AI PERSONALIZATION
-- -------------------------
CREATE TABLE ai_personalization.learner_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES schools.students(id),
    learning_style TEXT,
    strengths JSONB,
    weaknesses JSONB
);

-- -------------------------
-- GAMIFICATION
-- -------------------------
CREATE TABLE gamification.user_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    xp INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1
);

CREATE TABLE gamification.badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    criteria JSONB
);

-- -------------------------
-- COMMUNITY
-- -------------------------
CREATE TABLE community.study_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT,
    school_id UUID REFERENCES schools.schools(id)
);

-- -------------------------
-- ANALYTICS CORE
-- -------------------------
CREATE TABLE analytics.analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    event_type TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- APPENDED MIGRATIONS (034 - 040 EXACT)
-- =========================================================


-- =========================================================
-- ELIMUBUDDY AI - SUPABASE BACKEND MIGRATIONS (034 - 040)
-- FULL CONSOLIDATED PRODUCTION SCHEMA
-- =========================================================

-- NOTE:
-- This file combines migrations 034 to 040 exactly as generated
-- in the ElimuBuddy AI Supabase architecture build sequence.

-- =========================================================
-- MIGRATION 034 - BILLING SYSTEM
-- =========================================================

CREATE SCHEMA IF NOT EXISTS billing;

CREATE TABLE billing.subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2),
    currency VARCHAR(10) DEFAULT 'KES',
    billing_interval VARCHAR(50),
    features JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    school_id UUID REFERENCES schools.schools(id),
    plan_id UUID REFERENCES billing.subscription_plans(id),
    status VARCHAR(50),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.payment_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    school_id UUID REFERENCES schools.schools(id),
    amount NUMERIC(10,2),
    currency VARCHAR(10),
    payment_method VARCHAR(50),
    transaction_status VARCHAR(50),
    external_reference TEXT,
    provider VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.payment_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID REFERENCES billing.payment_transactions(id),
    status VARCHAR(50),
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    school_id UUID REFERENCES schools.schools(id),
    amount NUMERIC(10,2),
    currency VARCHAR(10),
    due_date TIMESTAMPTZ,
    status VARCHAR(50),
    invoice_number TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.school_licenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_id UUID REFERENCES schools.schools(id),
    license_type VARCHAR(100),
    max_students INTEGER,
    max_teachers INTEGER,
    status VARCHAR(50),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.affiliate_programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    affiliate_name TEXT,
    commission_rate NUMERIC(5,2),
    payout_method VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.affiliate_referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    affiliate_id UUID,
    referred_user_id UUID REFERENCES auth_system.profiles(id),
    commission_earned NUMERIC(10,2),
    status VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.referral_programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    referral_code TEXT,
    total_referrals INTEGER DEFAULT 0,
    rewards_earned NUMERIC(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.referral_rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referral_id UUID REFERENCES billing.referral_programs(id),
    reward_type VARCHAR(50),
    reward_value NUMERIC(10,2),
    status VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.billing_webhook_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider VARCHAR(50),
    event_type VARCHAR(100),
    payload JSONB,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE billing.revenue_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    total_revenue NUMERIC(12,2),
    subscription_revenue NUMERIC(12,2),
    school_revenue NUMERIC(12,2),
    affiliate_payouts NUMERIC(12,2),
    currency VARCHAR(10) DEFAULT 'KES',
    generated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE MATERIALIZED VIEW billing.revenue_dashboard AS
SELECT SUM(amount) AS total_revenue,
COUNT(*) AS total_transactions
FROM billing.payment_transactions
WHERE transaction_status = 'completed';

-- =========================================================
-- MIGRATION 035 - CERTIFICATES
-- =========================================================

CREATE SCHEMA IF NOT EXISTS certificates;

CREATE TABLE certificates.certificate_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    template_type VARCHAR(100),
    layout_config JSONB,
    design_assets JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificates.certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    student_id UUID REFERENCES schools.students(id),
    school_id UUID REFERENCES schools.schools(id),
    certificate_type VARCHAR(100),
    title TEXT,
    description TEXT,
    issued_by UUID REFERENCES auth_system.profiles(id),
    template_id UUID REFERENCES certificates.certificate_templates(id),
    certificate_hash TEXT UNIQUE,
    status VARCHAR(50),
    issued_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificates.mastery_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES schools.students(id),
    subject_id UUID REFERENCES curriculum.subjects(id),
    mastery_level VARCHAR(50),
    competency_scores JSONB,
    certificate_id UUID REFERENCES certificates.certificates(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificates.course_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES schools.students(id),
    course_name TEXT,
    completion_percentage NUMERIC(5,2),
    certificate_id UUID REFERENCES certificates.certificates(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificates.achievement_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES schools.students(id),
    achievement_title TEXT,
    achievement_category VARCHAR(100),
    points_awarded INTEGER,
    certificate_id UUID REFERENCES certificates.certificates(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- MIGRATION 036 - NOTIFICATIONS
-- =========================================================

CREATE SCHEMA IF NOT EXISTS notifications;

CREATE TABLE notifications.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    title TEXT,
    message TEXT,
    notification_type VARCHAR(100),
    priority VARCHAR(50),
    channel VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications.push_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    device_token TEXT,
    title TEXT,
    body TEXT,
    sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications.email_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    email TEXT,
    subject TEXT,
    body TEXT,
    status VARCHAR(50),
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications.sms_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    phone TEXT,
    message TEXT,
    status VARCHAR(50),
    provider VARCHAR(50),
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- MIGRATION 037 - AI ORCHESTRATION
-- =========================================================

CREATE SCHEMA IF NOT EXISTS ai_orchestration;

CREATE TABLE ai_orchestration.ai_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_name TEXT UNIQUE,
    agent_type VARCHAR(100),
    description TEXT,
    capabilities JSONB,
    status VARCHAR(50) DEFAULT 'active',
    version TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE ai_orchestration.ai_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id UUID REFERENCES ai_orchestration.ai_agents(id),
    task_type VARCHAR(100),
    input_data JSONB,
    output_data JSONB,
    status VARCHAR(50),
    priority VARCHAR(50),
    scheduled_for TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE ai_orchestration.ai_memory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    memory_type VARCHAR(100),
    memory_data JSONB,
    embedding VECTOR(1536),
    importance_score NUMERIC(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- MIGRATION 038 - SECURITY
-- =========================================================

CREATE SCHEMA IF NOT EXISTS security;

CREATE TABLE security.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth_system.profiles(id),
    action VARCHAR(100),
    table_name TEXT,
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE security.security_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type VARCHAR(100),
    severity VARCHAR(50),
    user_id UUID REFERENCES auth_system.profiles(id),
    description TEXT,
    metadata JSONB,
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- MIGRATION 039 - SEARCH + KNOWLEDGE GRAPH
-- =========================================================

CREATE SCHEMA IF NOT EXISTS search;

CREATE TABLE search.full_text_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_table TEXT,
    source_id UUID,
    title TEXT,
    content TEXT,
    document_type VARCHAR(100),
    tsv tsvector,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE search.vector_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_table TEXT,
    source_id UUID,
    content TEXT,
    embedding VECTOR(1536),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE search.knowledge_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_type VARCHAR(100),
    title TEXT,
    description TEXT,
    grade_level VARCHAR(50),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- MIGRATION 040 - OPTIMIZATION
-- =========================================================

CREATE SCHEMA IF NOT EXISTS optimization;

CREATE TABLE optimization.background_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_type VARCHAR(100),
    payload JSONB,
    status VARCHAR(50),
    priority INTEGER DEFAULT 5,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 5,
    run_at TIMESTAMPTZ,
    locked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE optimization.cache_store (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cache_key TEXT UNIQUE,
    cache_value JSONB,
    ttl_seconds INTEGER,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- END OF CONSOLIDATED MIGRATIONS
-- =========================================================


-- =========================================================
-- END MASTER SCHEMA 001 - 040
-- =========================================================
