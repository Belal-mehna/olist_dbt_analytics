with source as (
        select * from {{ source('olist', 'order_reviews') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    