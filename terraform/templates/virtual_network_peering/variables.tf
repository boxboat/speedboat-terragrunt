variable "hub_peering_pairs" {
    type = list(
        object(
            is_bidirectional = bool,
            name = string
        )
    )
}