with sellers as (
    select
        seller_id,
        zip_code,
        city,
        state
    from {{ ref('stg_sellers') }}
),

order_items as (
    select
        seller_id,
        order_id,
        price,
        freight_value
    from {{ ref('stg_order_items') }}
),

seller_performance as (
    -- تجميع المقاييس على مستوى البائع لمنع الـ Fan-out
    select
        seller_id,
        count(distinct order_id) as total_orders_handled,
        count(1) as total_items_sold,
        sum(price) as total_revenue,
        sum(freight_value) as total_freight_value,
        sum(price + freight_value) as total_gross_value
    from order_items
    group by 1
),

final as (
    select
        -- Primary Key
        s.seller_id,

        -- Geography Attributes
        s.zip_code,
        s.city,
        s.state,

        -- Sales Metrics
        coalesce(p.total_orders_handled, 0) as total_orders_handled,
        coalesce(p.total_items_sold, 0) as total_items_sold,
        coalesce(p.total_revenue, 0) as total_revenue,
        coalesce(p.total_freight_value, 0) as total_freight_value,
        coalesce(p.total_gross_value, 0) as total_gross_value

    from sellers s
    left join seller_performance p
        on s.seller_id = p.seller_id
)

select * from final