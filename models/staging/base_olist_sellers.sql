with source as (
        select * from {{ source('olist', 'sellers') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    