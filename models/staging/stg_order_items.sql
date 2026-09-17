with source as (
        select * from {{ source('olist', 'order_items') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    