with customers as (
    select
        customer_id,
        customer_unique_id,
        zip_code,
        city,
        state
    from {{ ref('stg_customers') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_status,
        purchased_at
    from {{ ref('stg_orders') }}
),

order_payments as (
    -- تجميع المدفوعات على مستوى الطلب أولاً لمنع الـ Fan-out
    select
        order_id,
        sum(payment_value) as total_payment_value
    from {{ ref('stg_order_payments') }}
    group by 1
),

customer_orders_joined as (
    -- ربط جلسات الشراء والطلبات بالعميل وقيمة كل طلب
    select
        c.customer_unique_id,
        c.city,
        c.state,
        o.order_id,
        o.purchased_at,
        coalesce(p.total_payment_value, 0) as order_amount
    from orders o
    inner join customers c
        on o.customer_id = c.customer_id
    left join order_payments p
        on o.order_id = p.order_id
    where o.order_status != 'canceled'
),

customer_aggregations as (
    -- تجميع السلوك الشرائي الحقيقي على مستوى العميل الفريد (customer_unique_id)
    select
        customer_unique_id,
        
        -- Dimensions (أخذ أحدث موقع جغرافي للعميل)
        max(city) as customer_city,
        max(state) as customer_state,

        -- Timestamps
        min(purchased_at) as first_order_timestamp,
        max(purchased_at) as most_recent_order_timestamp,

        -- Metrics
        count(distinct order_id) as total_orders_count,
        sum(order_amount) as total_lifetime_spend

    from customer_orders_joined
    group by 1
)

select
    -- Primary Key لجدول الأبعاد
    customer_unique_id,

    -- Attributes
    customer_city,
    customer_state,

    -- Timestamps
    first_order_timestamp,
    most_recent_order_timestamp,

    -- Metrics
    total_orders_count,
    total_lifetime_spend,

    -- Derived Flags
    case 
        when total_orders_count > 1 then true 
        else false 
    end as is_repeat_buyer

from customer_aggregations