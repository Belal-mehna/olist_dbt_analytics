with source as (
        select * from {{ source('olist', 'orders') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    