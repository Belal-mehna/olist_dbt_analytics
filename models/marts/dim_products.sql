with products as (
    select
        product_id,
        category_name,
        name_length,
        description_length,
        photos_count,
        weight_g,
        length_cm,
        height_cm,
        width_cm
    from {{ ref('stg_products') }}
),

category_translation as (
    select
        category_name_pt,
        category_name_en
    from {{ ref('stg_product_category_name_translation') }}
),

final as (
    select
        -- Primary Key
        p.product_id,

        -- Category Attributes (الاحتفاظ بالاسم البرتغالي وتزويد الترجمة الإنجليزية)
        p.category_name as product_category_name_pt,
        coalesce(
            t.category_name_en, 
            p.category_name, 
            'unknown'
        ) as product_category_name_english,

        -- Catalog Attributes
        coalesce(p.photos_count, 0) as product_photos_qty,
        p.name_length as product_name_length,
        p.description_length as product_description_length,

        -- Physical Metrics (أبعاد ووزن المنتج)
        p.weight_g,
        p.length_cm,
        p.height_cm,
        p.width_cm,

        -- Derived Metric (حساب حجم المنتج بالـ cm3 لتقييم تكاليف الشحن)
        (p.length_cm * p.height_cm * p.width_cm) as product_volume_cm3

    from products p
    left join category_translation t
        on p.category_name = t.category_name_pt
)

select * from final