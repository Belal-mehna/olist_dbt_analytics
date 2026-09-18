with orders as (
    select
        order_id,
        customer_id,
        order_status,
        purchased_at,
        approved_at,
        shipped_at,
        delivered_at,
        estimated_delivery_at
    from {{ ref('stg_orders') }}
),

customers as (
    select
        customer_id,
        customer_unique_id,
        city,
        state
    from {{ ref('stg_customers') }}
),

order_items_summary as (
    -- تجميع عناصر الطلب على مستوى الطلب لمنع الـ Fan-out والحفاظ على Grain الطلب الواحد
    select
        order_id,
        count(item_sequence) as total_items_count,
        count(distinct seller_id) as total_sellers_count,
        sum(price) as total_products_amount,
        sum(freight_value) as total_freight_amount,
        sum(price + freight_value) as total_order_item_amount
    from {{ ref('stg_order_items') }}
    group by 1
),

order_payments_summary as (
    -- تجميع المدفوعات على مستوى الطلب (تجنباً للتكرار عند دمج جدولين تفصيليين)
    select
        order_id,
        count(payment_sequence) as total_payment_sequential_count,
        sum(payment_value) as total_payment_amount
    from {{ ref('stg_order_payments') }}
    group by 1
),

final as (
    select
        -- Primary Key
        o.order_id,

        -- Foreign Keys
        o.customer_id,
        c.customer_unique_id,

        -- Timestamps
        o.purchased_at,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,

        -- Attributes
        o.order_status,
        c.city,
        c.state,

        -- Metrics from Order Items
        coalesce(i.total_items_count, 0) as total_items_count,
        coalesce(i.total_sellers_count, 0) as total_sellers_count,
        coalesce(i.total_products_amount, 0) as total_products_amount,
        coalesce(i.total_freight_amount, 0) as total_freight_amount,
        coalesce(i.total_order_item_amount, 0) as total_order_item_amount,

        -- Metrics from Payments
        coalesce(p.total_payment_sequential_count, 0) as total_payment_sequential_count,
        coalesce(p.total_payment_amount, 0) as total_payment_amount,

        -- Derived Flags
        case 
            when o.order_status = 'delivered' then true 
            else false 
        end as is_delivered

    from orders o
    left join customers c
        on o.customer_id = c.customer_id
    left join order_items_summary i
        on o.order_id = i.order_id
    left join order_payments_summary p
        on o.order_id = p.order_id
)

select * from final