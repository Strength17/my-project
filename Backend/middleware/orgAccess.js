import supabase from "../utils/supabaseClient.js";

export default async function orgAccess(req, res, next) {
  // 1️⃣ Assert authenticated user

  const userId = req.user?.sub; 
  if (!userId) {
    return res.status(401).json({ error: "Unauthenticated" });
  }

  // 2️⃣ Validate org_id presence and type
  const rawOrgId = req.params.org_id;
  if (!rawOrgId) {
    return res.status(400).json({ error: "Missing org_id" }); 
  }

  const orgId = Number(rawOrgId);
  if (!Number.isInteger(orgId) || orgId <= 0) {
    return res.status(400).json({ error: "Invalid org_id" });
  }

  // 3️⃣ Verify org exists (prevents phantom orgs)
  const { data: org, error: orgError } = await supabase
    .from("organisation")
    .select("id")
    .eq("id", orgId)
    .single();

  if (orgError || !org) {
    return res.status(404).json({ error: "Organization not found" });
  }

  console.log("AUTH CHECK", {
        userId,
        orgId
    });


  // 4️⃣ Verify membership
  const { data: membership, error: memberError } = await supabase
    .from("org_members")
    .select("role")
    .eq("user_id", userId)
    .eq("org_id", orgId)
    .single();

  // 5️⃣ Explicit authorization failure
  if (!membership) {
    // hides whether org exists or not
    return res.status(404).json({ error: "Organization not found" });
  }
  

  // 6️⃣ Attach trusted context
  req.org = {
    id: orgId,
    role: membership.role,
  };

  next();
}
