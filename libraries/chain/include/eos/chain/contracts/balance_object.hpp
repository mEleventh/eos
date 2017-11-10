/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */
#pragma once

#include <eos/chain/types.hpp>
#include <eos/chain/multi_index_includes.hpp>

#include <chainbase/chainbase.hpp>

namespace eosio { namespace chain { namespace contracts {

/**
 * @brief The balance_object class tracks the EOS balance for accounts
 */
class balance_object : public chainbase::object<balance_object_type, balance_object> {
   OBJECT_CTOR(balance_object)

   id_type id;
   types::account_name owner_name;
   types::share_type balance = 0;
};

struct by_owner_name;

using balance_multi_index = chainbase::shared_multi_index_container<
   balance_object,
   indexed_by<
      ordered_unique<tag<by_id>,
         member<balance_object, balance_object::id_type, &balance_object::id>
      >,
      ordered_unique<tag<by_owner_name>,
         member<balance_object, types::account_name, &balance_object::owner_name>
      >
   >
>;

} } // namespace eosio::chain::contracts

CHAINBASE_SET_INDEX_TYPE(eosio::chain::contracts::balance_object, eosio::chain::contracts::balance_multi_index)
