with source as (
        select * from {{ source('olist', 'products') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    