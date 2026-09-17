with source as (
        select * from {{ source('olist', 'customers') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    