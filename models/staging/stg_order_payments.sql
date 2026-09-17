with source as (
        select * from {{ source('olist', 'order_payments') }}
  ),
  renamed as (
      select
          order_id,
        payment_sequential as payment_sequence,
        payment_type,
        cast(payment_installments as integer) as installments_count,
        cast(payment_value as numeric) as payment_value

      from source
  )
  select * from renamed
    