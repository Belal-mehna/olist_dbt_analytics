with source as (
        select * from {{ source('olist', 'order_payments') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    