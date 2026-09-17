with source as (
        select * from {{ source('olist', 'order_items') }}
  ),
  renamed as (
      select
          order_id,
        order_item_id as item_sequence,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_at,
        cast(price as numeric) as price,
        cast(freight_value as numeric) as freight_value

      from source
  )
  select * from renamed
    