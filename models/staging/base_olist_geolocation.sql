with source as (
        select * from {{ source('olist', 'geolocation') }}
  ),
  renamed as (
      select
          

      from source
  )
  select * from renamed
    