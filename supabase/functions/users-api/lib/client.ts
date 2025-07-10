import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

let _supabase: SupabaseClient | null = null;

export const getSupabase = (): SupabaseClient => {
  if (!_supabase) {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY");
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error("SUPABASE_URL and SUPABASE_ANON_KEY must be set in environment variables");
    }
    
    _supabase = createClient(supabaseUrl, supabaseKey);
  }
  return _supabase;
};

// For backward compatibility
export const supabase = new Proxy({}, {
  get(_target, prop) {
    return getSupabase()[prop as keyof SupabaseClient];
  }
}) as SupabaseClient;
